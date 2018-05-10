require 'pry'

class RentalsController < ApplicationController
  def checkout
    movie_id = params[:movie_id]
    customer_id = params[:customer_id]

    movie = Movie.find_by(id: movie_id)
    customer = Customer.find_by(id: customer_id)

    # change movies_checked_out_count for customer
    # changes available_inventory for movie

    customer.movies_checked_out_count += 1
    customer.save

    checkout_date = Time.now
    due_date = checkout_date + 7

    rental = Rental.new(customer_id: customer_id, movie_id: movie_id, checkout_date: checkout_date, due_date: due_date)

    if rental.save
      render json: { id: rental.id }, status: :ok
    else
      render json: { errors: rental.errors.messages }, status: :bad_request
    end
  end

  #   def create
  #   pet = Pet.new(pet_params)
  #   pet.save!
  #   render json: { id: pet.id }, status: :ok
  # end


  def checkin
    movie = Movie.find_by(id: params[:movie_id])
    customer = Customer.find_by(id: params[:customer_id])
    head :not_found unless movie && customer

    customer.movies << movie

    if customer.save
      # render your rental as json
      rental = Rental.where(movie_id: movie.id, customer_id: customer, checkin_date: nil).take

      rental.checkin_date = DateTime.now

      render json: rental.as_json(only: [:id, :checkout_date, :due_date, :checkin_date]), status: :ok
    else
      render json: { errors: rental.errors.messages }, status: :bad_request
    end
  end

  # add logic for verifying that the checkin date is before the checkout date
end
