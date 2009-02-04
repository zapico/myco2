require 'test_helper'

class HelpsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:helps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_help
    assert_difference('Help.count') do
      post :create, :help => { }
    end

    assert_redirected_to help_path(assigns(:help))
  end

  def test_should_show_help
    get :show, :id => helps(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => helps(:one).id
    assert_response :success
  end

  def test_should_update_help
    put :update, :id => helps(:one).id, :help => { }
    assert_redirected_to help_path(assigns(:help))
  end

  def test_should_destroy_help
    assert_difference('Help.count', -1) do
      delete :destroy, :id => helps(:one).id
    end

    assert_redirected_to helps_path
  end
end
