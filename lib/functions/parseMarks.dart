import 'package:novynaplo/login_page.dart';

import 'utils.dart';
var jegyek;
var jegyArray = [];
var id = 0;

List<dynamic> parseAll(var input){
  try{
    jegyek = input["Evaluations"];
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

Evals set(var input){
  Evals temp = new Evals();
  temp.id = id++;
  temp.value = input["Value"];
  temp.numberValue = input["NumberValue"];
  temp.teacher = input["Teacher"];
  temp.type = input["Type"];
  temp.subject = input["Subject"];
  temp.theme = input["Theme"];
  temp.mode = input["Mode"];
  temp.weight = input["Weight"];
  temp.date = input["Date"];
  temp.createDate = input["CreatingTime"];
  return temp;
}

class Evals{
  var id,
  value,
  numberValue,
  teacher,
  type,
  subject,
  theme,
  mode,
  weight,
  date,
  createDate;
}