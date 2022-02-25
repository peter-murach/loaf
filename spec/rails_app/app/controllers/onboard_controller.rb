# frozen_string_literal: true

class OnboardController < ApplicationController
  breadcrumb "Onboard", :onboard_path, match: :exact

  def setup
    case params[:step]
    when "1"
      breadcrumb "Step 1", onboard_step_path(step: 1),
                 match: :exact, request_methods: %i[get]
      render :step1
    when "2"
      breadcrumb "Step 2", onboard_step_path(step: 2),
                 match: :exact, request_methods: %i[get post]
      render :step2
    when "3"
      breadcrumb "Step 3", onboard_step_path(step: 3),
                 match: :exact, request_methods: %i[get put]
      render :step3
    when "4"
      breadcrumb "Step 4", onboard_step_path(step: 4),
                 match: :exact, request_methods: %i[get patch]
      render :step4
    when "5"
      breadcrumb "Step 5", onboard_step_path(step: 5),
                 match: :exact, request_methods: %i[get delete]
      render :step5
    when "6"
      breadcrumb "Step 6", onboard_step_path(step: 6),
                 match: :exact, request_methods: :all
      render :step6
    else
      render :setup
    end
  end
end