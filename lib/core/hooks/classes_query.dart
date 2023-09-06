import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/classes.dart';
import '../models/term.dart';


UseQueryResult<ClassScheduleModel, dynamic> useFetchUNCourses(Map<String, String> headers, String term) {
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';
  return useQuery(['un_courses'], () async {
    // fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=UN&term_code=' + term,
        headers);
    /// parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}

UseQueryResult<ClassScheduleModel, dynamic> useFetchGRCourses(Map<String, String> headers, String term) {
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';
  return useQuery(['gr_courses'], () async {
    // fetch data
    String _response = NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=GR&term_code=' + term,
        headers) as String;
    /// parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}

UseQueryResult<AcademicTermModel, dynamic> useFetchAcademicTerm(Map<String, String> headers, String term) {
  final String academicTermEndpoint =
      'https://o17lydfach.execute-api.us-west-2.amazonaws.com/qa/v1/term/current';
  return useQuery(['academic_term'], () async {
    // fetch data
    String _response = await NetworkHelper().fetchData(academicTermEndpoint);
    /// parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// parse data
    final data = academicTermModelFromJson(_response);
    return data;
  });
}

/* fetches classes, finals, midterms */
UseQueryResult<List<Map<String, List<SectionData>>>, dynamic> useFetchAll() {

}




