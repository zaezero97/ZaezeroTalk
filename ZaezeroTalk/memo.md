#  <#Title#>


uid  = {
    email : value
    frind_count : 0
    name : value
}

->

uid ={
     UserInfo ={
    email : value
    name : value
    },
    Friends = {
        friendCount : value,
        uid : {
        email : value
        name : value
        }
    } 
}
