require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_pages
    assert_difference('Pages.count') do
      post :create, :pages => { }
    end

    assert_redirected_to pages_path(assigns(:pages))
  end

  def test_should_show_pages
    get :show, :id => pages(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => pages(:one).id
    assert_response :success
  end

  def test_should_update_pages
    put :update, :id => pages(:one).id, :pages => { }
    assert_redirected_to pages_path(assigns(:pages))
  end

  def test_should_destroy_pages
    assert_difference('Pages.count', -1) do
      delete :destroy, :id => pages(:one).id
    end

    assert_redirected_to pages_path
  end
end
