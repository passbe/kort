FactoryBot.define do
  factory :probe_docker, parent: :probe, class: Probes::Docker do
    path { "/var/docker.sock" }
    reference { "my_container" }
  end
end
