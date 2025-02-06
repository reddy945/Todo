const mongoose = require('mongoose');

mongoose.connect('mongodb+srv://Reddyxr:6y7XLhP6aUs4fJlB@reddy.u65sc.mongodb.net/?retryWrites=true&w=majority&appName=Reddy', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => {
    console.log("✅ MongoDB Connected");
  })
  .catch((err) => {
    console.error("❌ MongoDB Connection Error", err);
  });

module.exports = mongoose;
