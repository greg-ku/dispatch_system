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
    OwnCases: [Schema.Types.ObjectId]
}

CaseSchema = new Schema {
    Title: String
    Discription: String
    Salary:
        Payment: Number
        Unit: String
    Position: String
    Workday: [Begin: Date, End: Date]
    Owner: Schema.Types.ObjectId
    Candidates: [Schema.Types.ObjectId]
    CreateDate: { type: Date, default: Date.now }
    Updated: { type: Date, default: Date.now }
}

mongoose.model \Account, AccountSchema
mongoose.model \Profile, ProfileSchema
mongoose.model \Case, CaseSchema

# connect
mongoose.connect \mongodb://localhost/dispatch-dev
