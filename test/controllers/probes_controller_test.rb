require "test_helper"

class ProbesControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    create(:probe)
    get probes_url
    assert_response :success
  end

  test "should get show" do
    probe = create(:probe)
    get probe_url(probe)
    assert_response :success
  end

  test "should get new" do
    get new_probe_url
    assert_response :success
  end

  test "should get fields" do
    get fields_new_probe_url(type: "dns", format: :turbo_stream)
    assert_response :success
  end

  test "should get empty fields with invalid :type" do
    get fields_new_probe_url(type: "s", format: :turbo_stream)
    assert_response :unprocessable_entity
  end

  test "should create probe" do
    probe = build(:probe_dns)
    # Note: We need to merge and flatten settings here
    attributes = probe.attributes.except(
      :id.to_s,
      :settings.to_s,
      :created_at.to_s,
      :updated_at.to_s
    )
    attributes.merge!(probe.attributes["settings"])
    # Also Schedules
    attributes["schedules_attributes"] = { "0": { "expression": "Mon" } }
    assert_difference("Probe.count") do
      assert_difference("Schedule.count") do
        post probes_url, params: { probe: attributes }
      end
    end
    assert_redirected_to probe_url(Probe.first)
  end

  test "should not create probe with invalid :type" do
    attributes = build(:probe).attributes.slice(
      :name.to_s
    )
    attributes["type"] = "Bad"
    post probes_url, params: { probe: attributes }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    probe = create(:probe)
    get edit_probe_url(probe)
    assert_response :success
  end

  test "should update probe" do
    probe = create(:probe_dns)
    schedule = create(:schedule, target: probe)
    new_schedule_expression = "Fri"
    # Note: We need to merge and flatten settings here
    attributes = {
      name: "Tests probe New",
      description: "Hello!",
      tag_list: "alpha, beta, charlie",
      port: 55555,
      schedules_attributes: {
        "0": {
          "id": schedule.id,
          "_destroy": "1"
        },
        "1": {
          "id": "",
          "expression": new_schedule_expression,
          "_destroy": ""
        }
      }
    }
    patch probe_url(probe), params: { probe: attributes }
    assert_redirected_to probe_url(probe)
    # Note: Fiddle with the probe so STI works
    probe = probe.becomes!(Probes::Dns)
    assert_equal probe, Probe.first
    assert_not_equal schedule.id, Probe.first.schedules.first.id
    assert_equal new_schedule_expression, Probe.first.schedules.first.expression
  end

  test "should not update probe with invalid :type" do
    probe = create(:probe)
    attributes = { name: "Tests probe New", description: "Hello!", type: "bad" }
    patch probe_url(probe), params: { probe: attributes }
    assert_response :unprocessable_entity
  end

  test "should not execute if probe disabled" do
    probe = create(:probe, enabled: false)
    post execute_probe_url(probe)
    assert_redirected_to probe_url(probe)
  end

  test "should execute" do
    probe = create(:probe, enabled: true)
    execution = create(:execution, target: probe)
    Probe.any_instance.stubs(:execute).returns(execution)
    post execute_probe_url(probe)
    assert_redirected_to execution_url(execution)
  end

  test "should get confirm" do
    probe = create(:probe)
    get confirm_probe_url(probe)
    assert_response :success
  end

  test "should destroy probe" do
    probe = create(:probe)
    assert_difference("Probe.count", -1) do
      delete probe_url(probe)
    end
    assert_redirected_to probes_url
  end

end
