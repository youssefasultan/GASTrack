class DataManipulation {
  DataManipulation._();

  
  static List<dynamic> getUniqueObjects(List<dynamic> jsonList, String key) {
    return jsonList.fold<List<dynamic>>(
      [],
      (acc, obj) {
        if (!acc.any((item) => item[key] == obj[key])) {
          acc.add(obj);

        }
        return acc;
      },
    );
  }
}