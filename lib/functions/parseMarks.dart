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
  }on Error{
    return ["Error"];
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
  var _id,
  _value,
  _numberValue,
  _teacher,
  _type,
  _subject,
  _theme,
  _mode,
  _weight,
  _date,
  _createDate;

  get id => this._id;
  set id(input){
    this._id = input;
  }

  get value => this._value;
  set value(input){
    this._value = input;
  }

  get numberValue => this._numberValue;
  set numberValue(input){
    this._numberValue = input;
  }

  get teacher => this._teacher;
  set teacher(input){
    this._teacher = input;
  }

  get type => this._type;
  set type(input){
    this._type = input;
  }

  get subject => this._subject;
  set subject(input){
    this._subject = input;
  }

  get theme => this._theme;
  set theme(input){
    this._theme = input;
  }

  get mode => this._mode;
  set mode(input){
    this._mode = input;
  }

  get weight => this._weight;
  set weight(input){
    this._weight = input;
  }

  get date => this._date;
  set date(input){
    this._date = input;
  }

  get createDate => this._createDate;
  set createDate(input){
    this._createDate = input;
  }
}