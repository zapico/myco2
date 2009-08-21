require 'test_helper'

class GoalsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:goals)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_goal
    assert_difference('Goal.count') do
      post :create, :goal => { }
    end

    assert_redirected_to goal_path(assigns(:goal))
  end

  def test_should_show_goal
    get :show, :id => goals(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => goals(:one).id
    assert_response :success
  end

  def test_should_update_goal
    put :update, :id => goals(:one).id, :goal => { }
    assert_redirected_to goal_path(assigns(:goal))
  end

  def test_should_destroy_goal
    assert_difference('Goal.count', -1) do
      delete :destroy, :id => goals(:one).id
    end

    assert_redirected_to goals_path
  end
end
