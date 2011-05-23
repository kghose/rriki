require 'test_helper'

class DiaryTagsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:diary_tags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create diary_tags" do
    assert_difference('DiaryTags.count') do
      post :create, :diary_tags => { }
    end

    assert_redirected_to diary_tags_path(assigns(:diary_tags))
  end

  test "should show diary_tags" do
    get :show, :id => diary_tags(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => diary_tags(:one).to_param
    assert_response :success
  end

  test "should update diary_tags" do
    put :update, :id => diary_tags(:one).to_param, :diary_tags => { }
    assert_redirected_to diary_tags_path(assigns(:diary_tags))
  end

  test "should destroy diary_tags" do
    assert_difference('DiaryTags.count', -1) do
      delete :destroy, :id => diary_tags(:one).to_param
    end

    assert_redirected_to diary_tags_path
  end
end
