require "net/http"
require "uri"
require "base64"
require "json"
require "tempfile"

module Flashcards
  # Downloads a shared deck from AnkiWeb as an .apkg.
  #
  # AnkiWeb has no public API, so this mirrors what the ankiweb.net web app does:
  #
  #   1. GET /svc/shared/item-info?sharedId=<id>  -> a protobuf blob that, among
  #      other things, carries a short-lived signed "shared deck download" token.
  #   2. GET /svc/shared/download-deck/<id>?t=<token>  -> the .apkg bytes.
  #
  # The token is found by scanning the protobuf for a JWT-shaped string whose
  # header decodes to {"op":"sdd",...}, which keeps us resilient to field-number
  # changes in AnkiWeb's schema.
  #
  # Anonymous downloads are quota-limited by AnkiWeb; once the quota is used up it
  # replies with a plaintext message ("Please log in to download more decks.")
  # which we surface to the user.
  module AnkiWeb
    HOST = "ankiweb.net".freeze
    USER_AGENT = "Mather flashcard importer".freeze
    OPEN_TIMEOUT = 15
    READ_TIMEOUT = 60

    module_function

    # Returns [Tempfile, suggested_filename]. The caller is responsible for
    # closing/unlinking the tempfile (Tempfile#close!).
    def download(input)
      id = extract_id(input)
      raise ImportError, "Enter an AnkiWeb shared-deck link or its numeric ID." unless id

      token = fetch_download_token(id)
      body  = fetch_deck(id, token)

      file = Tempfile.new([ "ankiweb-#{id}-", ".apkg" ])
      file.binmode
      file.write(body)
      file.flush
      file.rewind
      [ file, "ankiweb-#{id}.apkg" ]
    end

    # Accepts a full shared/info URL or a bare numeric id.
    def extract_id(input)
      string = input.to_s
      match = string.match(%r{/shared/(?:info|download)/(\d+)}) ||
              string.match(/\A\s*(\d+)\s*\z/) ||
              string.match(/(\d{6,})/)
      match && match[1]
    end

    def fetch_download_token(id)
      response = get("/svc/shared/item-info?sharedId=#{id}")
      unless response.is_a?(Net::HTTPSuccess)
        raise ImportError, ankiweb_message(response, "Couldn't find that deck on AnkiWeb.")
      end

      token = scan_for_token(response.body.to_s.b)
      raise ImportError, "AnkiWeb didn't offer a download for that deck." unless token

      token
    end

    def fetch_deck(id, token)
      response = get("/svc/shared/download-deck/#{id}?t=#{token}")
      unless response.is_a?(Net::HTTPSuccess)
        raise ImportError, ankiweb_message(response, "AnkiWeb wouldn't let us download that deck.")
      end

      response.body
    end

    def get(path)
      uri = URI.parse("https://#{HOST}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = USER_AGENT
      http.request(request)
    rescue SocketError, Timeout::Error, SystemCallError, OpenSSL::SSL::SSLError => e
      raise ImportError, "Couldn't reach AnkiWeb (#{e.class.name.demodulize})."
    end

    # AnkiWeb returns short plaintext bodies on error; pass one through if it looks
    # like a human-readable message, otherwise fall back to our own wording.
    def ankiweb_message(response, fallback)
      body = response.body.to_s.strip
      body = body.dup.force_encoding("UTF-8")
      return fallback if body.blank? || body.bytesize > 200 || !body.valid_encoding?

      "AnkiWeb: #{body}"
    end

    # --- protobuf wire scanning -------------------------------------------------

    # Walk the length-delimited fields of a protobuf message (recursing into
    # nested messages) and return the first value that is a download token.
    def scan_for_token(buffer)
      pos = 0
      len = buffer.bytesize

      while pos < len
        key, pos = read_varint(buffer, pos, len)
        return nil if key.nil?

        case key & 7
        when 0 # varint
          _value, pos = read_varint(buffer, pos, len)
          return nil if pos.nil?
        when 2 # length-delimited
          length, pos = read_varint(buffer, pos, len)
          return nil if length.nil? || pos + length > len

          slice = buffer.byteslice(pos, length)
          pos += length

          return slice if download_token?(slice)

          found = scan_for_token(slice)
          return found if found
        when 5 # 32-bit
          pos += 4
        when 1 # 64-bit
          pos += 8
        else
          return nil
        end
      end

      nil
    end

    def read_varint(buffer, pos, len)
      result = 0
      shift = 0

      while pos < len
        byte = buffer.getbyte(pos)
        pos += 1
        result |= (byte & 0x7f) << shift
        return [ result, pos ] if byte < 0x80

        shift += 7
        return [ nil, nil ] if shift > 63
      end

      [ nil, nil ]
    end

    def download_token?(slice)
      string = slice.to_s.dup.force_encoding("UTF-8")
      return false unless string.valid_encoding?
      return false unless string.match?(/\A[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\z/)

      header = string.split(".", 2).first
      padded = header + ("=" * ((4 - header.bytesize % 4) % 4))
      JSON.parse(Base64.urlsafe_decode64(padded))["op"] == "sdd"
    rescue StandardError
      false
    end
  end
end
