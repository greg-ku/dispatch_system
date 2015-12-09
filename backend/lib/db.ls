require! mongoose
Schema = mongoose.Schema

ProfileSchema = new Schema {
    firstName: String
    lastName: String
    companyName: String
}

AccountSchema = new Schema {
    type: String
    name: String
    password: String
    eamil: String
    profile: ProfileSchema
    ownCases: [Schema.Types.ObjectId]
}

CaseSchema = new Schema {
    title: String
    discription: String
    salary:
        payment: Number
        unit: String
    position: String
    workday: [Begin: Date, End: Date]
    owner: Schema.Types.ObjectId
    candidates: [Schema.Types.ObjectId]
    createDate: { type: Date, default: Date.now }
    updated: { type: Date, default: Date.now }
}

mongoose.model \Account, AccountSchema
mongoose.model \Profile, ProfileSchema
mongoose.model \Case, CaseSchema

# connect
mongoose.connect \mongodb://localhost/dispatch-dev
