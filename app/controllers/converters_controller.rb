class ConvertersController < ApplicationController
  def new
    load_converter
  end

  def create
    load_converter
    build_converter

    @converter.save
    render :new
  end

  private

  def load_converter
    @converter ||= Converter.new
  end

  def build_converter
    @converter.attributes = converter_params
  end

  def converter_params
    converter_params = params[:converter]
    converter_params ? converter_params.permit(:source, :from_syntax, :output) : {}
  end
end
