class SettingsController < ApplicationController
  def show
  end

  def update
    types = Array(params[:active_types]).select { |t| Questions::Registry.key?(t) }
    types = Questions::Registry.all_keys.dup if types.empty?

    session[:settings] = {
      "active_types" => types,
      "difficulty"   => params[:difficulty].to_i.clamp(0, 3)
    }

    redirect_to practice_path, notice: "Settings saved!"
  end
end
