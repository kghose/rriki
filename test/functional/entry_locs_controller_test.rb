require 'test_helper'

class EntryLocsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entry_locs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create entry_loc" do
    assert_difference('EntryLoc.count') do
      post :create, :entry_loc => { }
    end

    assert_redirected_to entry_loc_path(assigns(:entry_loc))
  end

  test "should show entry_loc" do
    get :show, :id => entry_locs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => entry_locs(:one).to_param
    assert_response :success
  end

  test "should update entry_loc" do
    put :update, :id => entry_locs(:one).to_param, :entry_loc => { }
    assert_redirected_to entry_loc_path(assigns(:entry_loc))
  end

  test "should destroy entry_loc" do
    assert_difference('EntryLoc.count', -1) do
      delete :destroy, :id => entry_locs(:one).to_param
    end

    assert_redirected_to entry_locs_path
  end
end
