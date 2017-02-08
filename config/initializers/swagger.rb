Swagger::Docs::Config.register_apis(
  '1.0' => {
    # the extension used for the API
    api_extension_type: :json,
    # the output location where your .json files are written to
    api_file_path: 'public/apidocs/',
    # the URL base path to your API
    base_path: 'http://api.somedomain.com',
    # if you want to delete all .json files at each generation
    clean_directory: true,
    # Ability to setup base controller for each api version. Api::V1::SomeController for example.
    parent_controller: Api::V1::ApplicationController,
    # add custom attributes to api-docs
    attributes: {
      info: {
        'title' => 'Swagger Todo',
        'description' => 'This is an API to manage todo list',
        'termsOfServiceUrl' => 'http://helloreverb.com/terms/',
        'contact' => 'wakim.jraige@gmail.com'
      }
    }
  }
)
