import 'utils.dart';
var id = 0;

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

class Avarage{
  var subject,
  ownValue,
  classValue,
  diff;
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

Avarage setAvarage(var subject,ownValue,classValue,diff){
  Avarage temp = new Avarage();
  temp.subject = capitalize(subject);
  temp.ownValue = ownValue;
  temp.classValue = classValue;
  temp.diff = diff;
  return temp;
}