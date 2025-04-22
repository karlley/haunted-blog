# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :require_blog_owner, only: %i[edit update destroy]
  before_action :authorize_random_eyecatch, only: %i[create update]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    return unless @blog.secret
    return unless !user_signed_in? || @blog.user != current_user

    raise ActiveRecord::RecordNotFound
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def require_blog_owner
    return if current_user == @blog.user

    raise ActiveRecord::RecordNotFound
  end

  def authorize_random_eyecatch
    return unless !current_user.premium && blog_params[:random_eyecatch].present?

    redirect_to request.referer || root_path, alert: 'Only premium users can enable random eyecatch.'
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end
end
