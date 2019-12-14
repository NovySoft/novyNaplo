import 'package:novynaplo/screens/login_page.dart';
import 'utils.dart';
import 'package:novynaplo/helpers/subjectAssignHelper.dart';
var id = 0;

class Evals{
  var formName,
  form,
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

class Avarage{
  var subject,
  ownValue,
  classValue,
  diff;
}

Evals setEvals(var input){
  Evals temp = new Evals();
  //Magatartas es Szorgalom
  if(input["Subject"] == null || input["Subject"] == ""){
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
  if(input["Theme"] == null || input["Theme"] == ""){
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
  if(input["Mode"] == null || input["Mode"] == ""){
    temp.mode = input["TypeName"];
  }else{
    temp.mode = input["Mode"];
  }
  //Ertekeles sulya
  if(input["Weight"] == null || input["Weight"] == "" || input["Weight"] == "-"){
    if(input["Form"] != "Percent"){
      temp.weight = "100%";
    }else{
      temp.weight = "0%";
    }
    //feltehetoleg 100%osan beleszámít, pl a szorgalomnal is igy van
  }else{
    temp.weight = input["Weight"];
  }
  temp.id = id++;
  temp.value = input["Value"];
  temp.formName = input["FormName"];
  temp.form = input["Form"];
  temp.teacher = input["Teacher"];
  temp.type = input["Type"];
  temp.date = input["Date"];
  temp.createDate = input["CreatingTime"];
  return temp;
}

Avarage setAvarage(var subject,ownValue,classValue,diff){
  Avarage temp = new Avarage();
  temp.subject = capitalize(subject);
  temp.ownValue = ownValue;
  temp.classValue = classValue;
  temp.diff = diff;
  return temp;
}

class Notices{
  var title,
  content,
  teacher,
  date,
  subject;
}

Notices setNotices(var input){
  Notices temp = new Notices();
  temp.title = capitalize(input["Title"]);
  temp.teacher = input["Teacher"];
  temp.content = input["Content"];
  temp.date = input["CreatingTime"];
  if(input["OsztalyCsoportUid"] == null){
    temp.subject = null;
  }else{
    temp.subject = SubjectAssignHelper().assignSubject(dJson,input["OsztalyCsoportUid"],input["Type"],input["Content"]);
  }
  return temp;
}