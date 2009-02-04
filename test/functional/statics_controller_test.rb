require 'test_helper'

class StaticsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:statics)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_static
    assert_difference('Static.count') do
      post :create, :static => { }
    end

    assert_redirected_to static_path(assigns(:static))
  end

  def test_should_show_static
    get :show, :id => statics(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => statics(:one).id
    assert_response :success
  end

  def test_should_update_static
    put :update, :id => statics(:one).id, :static => { }
    assert_redirected_to static_path(assigns(:static))
  end

  def test_should_destroy_static
    assert_difference('Static.count', -1) do
      delete :destroy, :id => statics(:one).id
    end

    assert_redirected_to statics_path
  end
end
