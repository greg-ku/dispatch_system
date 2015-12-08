require! mongoose
Schema = mongoose.Schema

ProfileSchema = new Schema {
    FirstName: String
    LastName: String
    CompanyName: String
}

AccountSchema = new Schema {
    Type: String
    Name: String
    Password: String
    Eamil: String
    Profile: ProfileSchema
}

mongoose.model \Account, AccountSchema
mongoose.model \Profile, ProfileSchema

# connect
mongoose.connect \mongodb://localhost/dispatch-dev
