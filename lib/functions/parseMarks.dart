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
  //Magatartas es Szorgalom
  if(input["Subject"] == null){
    temp.subject = input["Jelleg"]["Nev"];
  }else{
    temp.subject = input["Subject"];
  }
  //Magatartas es Szorgalom integer
  if(input["NumberValue"] == 0 && input["Form"] != "Percent"){
    switch (input["Value"]) {
      case "Rossz":
        temp.numberValue = 2;
        break;
      case "Változó":
        temp.numberValue = 3;
        break;
      case "Jó":
        temp.numberValue = 4;
        break;
      case "Példás":
        temp.numberValue = 5;
        break;
      default:
        temp.numberValue = 0;
        break;
    }
  }else{
    temp.numberValue = input["NumberValue"];
  }
  //Ertekeles temaja
  if(input["Theme"] == null){
    if(input["Mode"] != null){
      temp.theme = input["Mode"];
    }else{
      //There is no other option than typeName
      temp.theme = input["TypeName"];
    }
  }else{
    temp.theme = input["Theme"];
  }
  //Ertekeles modja
  if(input["Mode"] == null){
    temp.mode = input["TypeName"];
  }else{
    temp.mode = input["Mode"];
  }
  //Ertekeles sulya
  if(input["Weight"] == null){
    temp.weight = "100%"; //feltehetoleg 100%osan beleszámít, pl a szorgalomnal is igy van
  }else{
    temp.weight = input["Weight"];
  }
  temp.id = id++;
  temp.value = input["Value"];
  temp.form = input["Form"];
  temp.teacher = input["Teacher"];
  temp.type = input["Type"];
  temp.date = input["Date"];
  temp.createDate = input["CreatingTime"];
  return temp;
}

class Evals{
  var form,
  id,
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