// Initialize WebHooks module.
const hookcord = require("hookcord");
const Hook = new hookcord.Hook();
//Get command line arguments
var myArgs = process.argv.slice(2);
var message = [];
var commitMessage = "";
var index = 0;
console.log("myArgs: ", myArgs);
//arg0: LoginID
//arg1: Secret
//arg2: fail/success/starting
//arg3: $TRAVIS_BUILD_WEB_URL/deploy url/error message
//arg4: $TRAVIS_BUILD_NUMBER
//arg5: Commit message

myArgs.forEach(element => {
  if(index>=5){
    message.push(element);
  }
  index++;
});

message.forEach(element => {
  let tempString = " " + element;
  commitMessage += tempString;
});

//Get date
var today = new Date();
var dd = String(today.getDate()).padStart(2, "0");
var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
var yyyy = today.getFullYear();
today = yyyy + "/" + mm + "/" + dd;

//Login with discord hook
Hook.login(
  myArgs[0],
  myArgs[1]
);

//Create payload
if (myArgs[2] == "fail") {
  Hook.setPayload({
    embeds: [
      {
        color: 15158332,
        title: "**Travis CI status:**",
        footer: {
          icon_url:
            "https://cdn.discordapp.com/avatars/327050684044148736/71ae85a573690901d4fd07a0e452df19.png?size=128",
          text: "Travis CI webhook by Novy"
        },
        thumbnail: {
          url: "https://retohercules.com/images/cross-icon-png-14.png"
          //https://bandat-nhontrach.com/images/green-check-mark-png-8.png
        },
        author: {
          name: "Travis bot",
          url: "https://travis-ci.com/NovySoft/novyNaplo",
          icon_url: "https://travis-ci.com/images/logos/Tessa-pride.png"
        },
        fields: [
          {
            name: "Status:",
            value: "```FAIL!```"
          },
          {
            name: "Error:",
            value: myArgs[3]
          },
          {
            name: "Date:",
            value: today
          },
        ]
      }
    ]
  });
} else if (myArgs[2] == "success") {
  Hook.setPayload({
    embeds: [
      {
        color: 3066993,
        title: "**Travis CI status:**",
        footer: {
          icon_url:
            "https://cdn.discordapp.com/avatars/327050684044148736/71ae85a573690901d4fd07a0e452df19.png?size=128",
          text: "Travis CI webhook by Novy"
        },
        thumbnail: {
          url: "https://bandat-nhontrach.com/images/green-check-mark-png-8.png"
          //https://retohercules.com/images/cross-icon-png-14.png
        },
        author: {
          name: "Travis bot",
          url: "https://travis-ci.com/NovySoft/novyNaplo",
          icon_url: "https://travis-ci.com/images/logos/Tessa-pride.png"
        },
        fields: [
          {
            name: "Status:",
            value: "```SUCCESS!```"
          },
          {
            name: "Deploy url:",
            value: myArgs[3]
          },
          {
            name: "Date:",
            value: today
          }
        ]
      }
    ]
  });
} else if (myArgs[2] == "starting") {
  Hook.setPayload({
    embeds: [
      {
        color: 1752220,
        title: "**Travis CI status:**",
        footer: {
          icon_url:
            "https://cdn.discordapp.com/avatars/327050684044148736/71ae85a573690901d4fd07a0e452df19.png?size=128",
          text: "Travis CI webhook by Novy"
        },
        thumbnail: {
          url: "https://www.yevaz.com/pasajeros/images/preload.gif"
          //https://retohercules.com/images/cross-icon-png-14.png
        },
        author: {
          name: "Travis bot",
          url: "https://travis-ci.com/NovySoft/novyNaplo",
          icon_url: "https://travis-ci.com/images/logos/Tessa-pride.png"
        },
        fields: [
          {
            name: "Status:",
            value: "```Starting up!```"
          },
          {
            name: "Commit message:",
            value: commitMessage,
          },
          {
            name: "URL + Build number:",
            value: myArgs[3] + " (" + myArgs[4] + ")",
          },
          {
            name: "Date:",
            value: today
          }
        ]
      }
    ]
  });
}

Hook.fire()
  .then(response_object => {
    console.log(response_object);
  })
  .catch(error => {
    throw error;
  });
