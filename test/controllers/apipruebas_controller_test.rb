require "test_helper"

class ApipruebasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apiprueba = apipruebas(:one)
  end

  test "should get index" do
    get apipruebas_url, as: :json
    assert_response :success
  end

  test "should create apiprueba" do
    assert_difference("Apiprueba.count") do
      post apipruebas_url, params: { apiprueba: { string: @apiprueba.string, username: @apiprueba.username } }, as: :json
    end

    assert_response :created
  end

  test "should show apiprueba" do
    get apiprueba_url(@apiprueba), as: :json
    assert_response :success
  end

  test "should update apiprueba" do
    patch apiprueba_url(@apiprueba), params: { apiprueba: { string: @apiprueba.string, username: @apiprueba.username } }, as: :json
    assert_response :success
  end

  test "should destroy apiprueba" do
    assert_difference("Apiprueba.count", -1) do
      delete apiprueba_url(@apiprueba), as: :json
    end

    assert_response :no_content
  end
end
