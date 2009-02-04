require 'test_helper'

class DevicesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:devices)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_device
    assert_difference('Device.count') do
      post :create, :device => { }
    end

    assert_redirected_to device_path(assigns(:device))
  end

  def test_should_show_device
    get :show, :id => devices(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => devices(:one).id
    assert_response :success
  end

  def test_should_update_device
    put :update, :id => devices(:one).id, :device => { }
    assert_redirected_to device_path(assigns(:device))
  end

  def test_should_destroy_device
    assert_difference('Device.count', -1) do
      delete :destroy, :id => devices(:one).id
    end

    assert_redirected_to devices_path
  end
end
