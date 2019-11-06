# Cnfs CLI

- Platform - The overall project is a platform
- Partitions - Application, Infra
- Components - Infra::Kubernetes, Application::Backend
- Resources - Application::Backend::Rails, Infra::Kubernetes::Fluentd
- Units -

- Cnfs::Platform::Partition::Component::Resource
- Cnfs::Platform::Application::Backend::Rails::Config
- Cnfs::Platform::Application::Backend::Rails::Unit

## Explained

platform.yml defines the partitions
providers.yml can be at platform or partition level

There is a default configuration in cnfs-core/config.
A CNFS project will define a set of configuration files laid out in an identical manner that overrides
the inherited defaults 

```bash
|-- application
|   |-- backend
|   |    - rails.yml
|   |-- backend.yml
|   |-- frontend.yml
|    - pipeline.yml
|-- application.yml
|-- environments
|   |-- development
|   |   `- application
|   |      `- backend
|   |          `- rails.yml
|   |-- production
|   |   `- infra.yml
|   `- production-uat
|      `- application.yml
|-- infra.yml
|-- platform.yml
`- providers.yml
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cnfs-cli.
