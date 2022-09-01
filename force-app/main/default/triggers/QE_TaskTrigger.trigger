trigger QE_TaskTrigger on Task (before insert) {
  for(Task task : Trigger.new) {
    if (task.Description != null) {
      String description = task.Description;
      String regExp = 'reset_password_token=.+?\\)';
      String replacement = 'reset_password_token=fake)';
      String replaced = description.replaceAll(regExp, replacement);
      task.Description = replaced;
    }
  }
}