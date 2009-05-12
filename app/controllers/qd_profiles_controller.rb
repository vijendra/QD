class QdProfilesController < ApplicationController

  def index
    @qd_profiles = current_user.qd_profiles
    @fields_to_be_shown = current_user.dealer_field.fields rescue []
    puts "ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp #{@fields_to_be_shown}"
  end
end
