class CreateProgramParam {
  final String name;

  const CreateProgramParam({required this.name});

  Map<String, String> toJson(CreateProgramParam params) => {
    'name': params.name,
  };
}
