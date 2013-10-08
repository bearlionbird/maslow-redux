require 'gds_api/need_api'
require 'plek'

class NeedsController < ApplicationController

  JUSTIFICATIONS = ["legislation", "obligation", "other"]
  IMPACT = [
    "Endangers the health of individuals",
    "Has serious consequences for the day-to-day lives of your users",
    "Annoys the majority of your users. May incur fines",
    "Noticed by the average member of the public",
    "Noticed by an expert audience",
    "No impact"
  ]
  ORGANISATIONS = [
    ["Ministry of Justice","ministry-of-justice"],
    ["Competition Commission","competition-commission"]
  ]

  def need_api_submitter
    GdsApi::NeedApi.new(Plek.current.find('need-api'))
  end

  def index
  end

  def new
    @need = Need.new({})
    @justifications = JUSTIFICATIONS
    @impact = IMPACT
    @organisations = ORGANISATIONS
  end

  def create
    # Rails inserts an empty string into multi-valued fields.
    # We are removing the unneeded value
    if params["need"]
      if params["need"]["justifications"]
        params["need"]["justifications"].select!(&:present?)
      end
      if params["need"]["organisation_ids"]
        params["need"]["organisation_ids"].select!(&:present?)
      end
      if params["need"]["met_when"]
        params["need"]["met_when"] = params["need"]["met_when"].split("\n").map(&:strip)
      end
    else
      raise(ArgumentError, "Need data not found")
    end
    @need = Need.new(params["need"])

    if @need.valid?
      need_api_submitter.create_need(@need)
      redirect_to("/")
    else
      @justifications = JUSTIFICATIONS
      @impact = IMPACT
      @organisations = ORGANISATIONS
      @need.met_when = @need.met_when.try do |f|
        f.join("\n")
      end
      render "new", :status => :unprocessable_entity
    end
  end
end
