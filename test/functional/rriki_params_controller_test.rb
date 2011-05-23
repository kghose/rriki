require 'test_helper'

class RrikiParamsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rriki_params)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rriki_params" do
    assert_difference('RrikiParams.count') do
      post :create, :rriki_params => { }
    end

    assert_redirected_to rriki_params_path(assigns(:rriki_params))
  end

  test "should show rriki_params" do
    get :show, :id => rriki_params(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => rriki_params(:one).to_param
    assert_response :success
  end

  test "should update rriki_params" do
    put :update, :id => rriki_params(:one).to_param, :rriki_params => { }
    assert_redirected_to rriki_params_path(assigns(:rriki_params))
  end

  test "should destroy rriki_params" do
    assert_difference('RrikiParams.count', -1) do
      delete :destroy, :id => rriki_params(:one).to_param
    end

    assert_redirected_to rriki_params_path
  end
end
