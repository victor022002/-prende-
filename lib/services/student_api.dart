import 'api_service.dart';

class StudentApi {
  final ApiService _api = ApiService();

  Future<List> getStudents() async {
    final res = await _api.get("/students");
    return res["data"];
  }

  Future<Map> createStudent(Map student) async {
    return await _api.post("/students/create", student);
  }

  Future<Map> deleteStudent(String id) async {
    return await _api.post("/students/delete", {"id": id});
  }

  Future<Map> updateProgress(String id, Map progress) async {
    return await _api.post("/students/progress", {
      "id": id,
      "progress": progress
    });
  }
}
