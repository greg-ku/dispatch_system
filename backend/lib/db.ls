require! mongoose
Schema = mongoose.Schema

Account = new Schema {
    Type: String,
    Name: String,
    Email: String,
    Password: String,
    MessageID: Schema.Types.ObjectId
}

mongoose.model \Account, Account

# connect
mongoose.connect \mongodb://localhost/dispatch-dev
