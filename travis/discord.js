// Initialize WebHooks module.
const hookcord = require("hookcord");
const Hook = new hookcord.Hook();
//Get command line arguments
var myArgs = process.argv.slice(2);
//arg0: fail/success/deployed/starting
//Get enviroment variables
var loginID = process.env.DISCORDID;
var secret = process.env.DISCORDSECRET;
var travisBuildUrl = process.env.TRAVIS_BUILD_WEB_URL;
var travisBuildNum = process.env.TRAVIS_BUILD_NUMBER;
var gitMessage = process.env.GIT_MESSAGE;
var gitBranch = process.env.TRAVIS_BRANCH;
var travisBuildTag = process.env.TRAVIS_TAG;
var travisBuildResult = process.env.TRAVIS_TEST_RESULT;
var travisBuildTrigger = "```" + process.env.TRAVIS_EVENT_TYPE + "```";

if (gitBranch === "master") {
  var nextStatus = "```Starting deploy!```";
} else {
  var nextStatus = "```Finished, not going to deploy!```";
}

var deployUrl = "https://github.com/NovySoft/novyNaplo/releases/tag/";
deployUrl += travisBuildTag;

//Get date
var today = new Date();
var dd = String(today.getDate()).padStart(2, "0");
var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
var yyyy = today.getFullYear();
today = yyyy + "/" + mm + "/" + dd;

//For testing
today = null;

//Login with discord hook
Hook.login(loginID, secret);

//Create payload
if (myArgs[0] === "fail") {
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
            name: "Test result (Error code):",
            value: travisBuildResult
          },
          {
            name: "Error:",
            value: "```Unknown```"
          },
          {
            name: "Travis url + build number:",
            value: travisBuildUrl + " (" + travisBuildNum + ")"
          },
          {
            name: "Commit message:",
            value: gitMessage
          },
          {
            name: "Date:",
            value: today
          }
        ]
      }
    ]
  });
} else if (myArgs[0] === "success") {
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
            name: "New status:",
            value: nextStatus
          },
          {
            name: "URL + Build number:",
            value: travisBuildUrl + " (" + travisBuildNum + ")"
          },
          {
            name: "Commit message:",
            value: gitMessage
          },
          {
            name: "Date:",
            value: today
          }
        ]
      }
    ]
  });
} else if (myArgs[0] === "starting") {
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
            name: "Triggered by:",
            value: travisBuildTrigger
          },
          {
            name: "URL + Build number:",
            value: travisBuildUrl + " (" + travisBuildNum + ")"
          },
          {
            name: "Commit message:",
            value: gitMessage
          },
          {
            name: "Date:",
            value: today
          }
        ]
      }
    ]
  });
} else if (myArgs[0] === "deployed") {
  Hook.setPayload({
    embeds: [
      {
        color: 65535,
        title: "**Travis CI status:**",
        footer: {
          icon_url:
            "https://cdn.discordapp.com/avatars/327050684044148736/71ae85a573690901d4fd07a0e452df19.png?size=128",
          text: "Travis CI webhook by Novy"
        },
        thumbnail: {
          url:
            "https://i.pinimg.com/originals/70/a5/52/70a552e8e955049c8587b2d7606cd6a6.gif"
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
            value: "```Deployed!```"
          },
          {
            name: "Deploy url:",
            value: deployUrl
          },
          {
            name: "Travis url + build number:",
            value: travisBuildUrl + " (" + travisBuildNum + ")"
          },
          {
            name: "Commit message:",
            value: gitMessage
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
  .then((response_object) => {
    console.log(response_object);
  })
  .catch((error) => {
    console.log(error);
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
              value: "```FAILED TO SEND DISCORD MESSAGE!```"
            },
            {
              name: "Error:",
              value: error
            },
            {
              name: "Date:",
              value: today
            }
          ]
        }
      ]
    });
    Hook.fire()
      .then((response_object) => {
        console.log(response_object);
      })
      .catch((error) => {
        throw error;
      })
  });
