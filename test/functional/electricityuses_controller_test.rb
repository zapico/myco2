require 'test_helper'

class ElectricityusesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:electricityuses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_electricityuse
    assert_difference('Electricityuse.count') do
      post :create, :electricityuse => { }
    end

    assert_redirected_to electricityuse_path(assigns(:electricityuse))
  end

  def test_should_show_electricityuse
    get :show, :id => electricityuses(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => electricityuses(:one).id
    assert_response :success
  end

  def test_should_update_electricityuse
    put :update, :id => electricityuses(:one).id, :electricityuse => { }
    assert_redirected_to electricityuse_path(assigns(:electricityuse))
  end

  def test_should_destroy_electricityuse
    assert_difference('Electricityuse.count', -1) do
      delete :destroy, :id => electricityuses(:one).id
    end

    assert_redirected_to electricityuses_path
  end
end
