List<User> userUpdates = new List<User>();

for (User u : [SELECT Id, IsActive FROM User WHERE Profile.UserLicense.Name = 'Salesforce' AND IsActive = TRUE AND Profile.Name != 'System Administrator']) {
    User userUpdate = new User();
    userUpdate.Id = u.Id;
    userUpdate.IsActive = false;
    userUpdates.add(userUpdate);
}

update userUpdates;