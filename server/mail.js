const mailjet = require ('node-mailjet')
.connect('3b0e1c67f4679d17fc495e73719620de', 'aece2354b72620d671b1f7f2af8eb593')
const request = mailjet
.post("send", {'version': 'v3.1'})
.request({
  "Messages":[
    {
      "From": {
        "Email": "mail@dao.af",
        "Name": "Eric"
      },
      "To": [
        {
          "Email": "mail@dao.af",
          "Name": "Eric"
        }
      ],
      "Subject": "method test from Mailjet.",
      "TextPart": "My first Mailjet email",
      "HTMLPart": "<h3>Dear passenger 1, welcome to <a href='https://www.mailjet.com/'>Mailjet</a>!</h3><br />May the delivery force be with you!",
      "CustomID": "AppGettingStartedTest"
    }
  ]
})
Meteor.methods({
  'mail'({ }) {
        request
          .then((result) => {
            console.log(result.body)
          })
          .catch((err) => {
            console.log(err.statusCode)
          })
  }
  })
