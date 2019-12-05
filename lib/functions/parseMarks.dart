import 'utils.dart';
import 'classManager.dart';
var jegyek;
var jegyArray = [];
var atlagArray = [];

List<dynamic> parseAll(var input){
  try{
    jegyek = input["Evaluations"];
    jegyArray = [];
    id = 0;
    jegyek.forEach(
      (n) => jegyArray.add(set(n))
    );
  }on Error catch (e){
    return [e];
  }
  return jegyArray;
}

List<String> parseMarks(var input){
  List<String> evalArray = [];
  var evalJegy = parseAll(input);
  if(evalJegy[0] == "Error") return ["Error"];
  evalJegy.forEach(
      (n) => evalArray.add(capitalize(n.subject + " " + n.value))
  );
  return evalArray;
}

List<dynamic> parseAvarages(var input){
  try{
    var atlagok = input["SubjectAverages"];
    atlagok.forEach(
      (n) => atlagArray.add(setAvarage(n["Subject"], n["Value"], n["classValue"], n["Difference"]))
    );
  }on Error catch (e){
    return [e.toString()];
  }
  return atlagArray;
}

int countAvarages(var input){
  var count = 0;
    var atlagok = input["SubjectAverages"];
    atlagok.forEach(
      (n) => count++
    );
  return count;
}