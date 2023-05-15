variable listofobjects {
    type = list(object){
        location = string
        age = number
    }
    ))
    default = [
        {
            location = "hyderabad"
            age = 20
        },
        {
            location = "kolkata"
            age = 10
        },
        {
            location = "bangalore"
            age = 30
            name = "ritesh"
        }
    ]
}
