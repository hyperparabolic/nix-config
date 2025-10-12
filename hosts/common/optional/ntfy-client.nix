{
  hyperparabolic.ntfy = {
    enableUserService = true;
    settings = {
      subscribe = [
        {
          topic = "notification";
          command = "notify-send \"$topic - $t\" \"$m\"";
        }
        {
          topic = "email";
          command = "notify-send \"$topic - $t\" \"$m\"";
        }
        {
          topic = "alert";
          command = "notify-send -u critical \"$topic - $t\" \"$m\"";
        }
      ];
    };
  };
}
