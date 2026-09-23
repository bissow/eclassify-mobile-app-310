enum CustomFieldType {
  radio('radio'),
  textbox('textbox'),
  number('number'),
  checkbox('checkbox'),
  dropdown('dropdown'),
  file('fileinput'),
  unknown('unknown');

  const CustomFieldType(this.key);

  final String key;

  static CustomFieldType parse(String value) {
    return CustomFieldType.values.firstWhere(
      (element) => element.key == value,
      orElse: () => CustomFieldType.unknown,
    );
  }
}
