class ImportFromCsv < ActiveRecord::Migration
  require 'hpricot'
  require 'mechanize'

  def self.up
    agent = WWW::Mechanize.new
    page = agent.get("http://www.qdrobot.com/robot1/admin/")
    login_form = page.forms[0]
    login_form.login = 'admin'
    login_form.EC = 'admin'
    login_form.pw = ''
    login_form.password = 'eab24a7a510b968c031d85435fc94af4'
    page = agent.submit(login_form)
    puts "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk #{page.links}"
    page = agent.get("http://www.qdrobot.com/robot1/admin/?EC=EditDealer&id=267")
    dealer_form = page.forms[0]
    dealer_form.fields.map{|field| puts"ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp #{field.name} %%%%%%%%%% #{field.value}"}
    ids = ['267','266','265','264','263','262','261','260','259','258','257','256','255','254','253','252','251','250','249','248',
   '247','246','245','244','243','242','241','240','239','238','237','236','235','234','233','232','231','230','229','228','227',
   '226','225','224','223','222','219','218','217','216','215','214','213','212','211','210','209','208','207','206','205','204',
   '203','202','201','200','199','198','197','196','195','194','193','192','191','190','189','188','187','186','185','184','183',
   '182','181','180','179','178','177','176','175','174','173','172','171','170','169','168','167','166','165','164','163','162',
   '161','160','159','157','156','155','154','153','151','150','149','148','147','146','145','144','143','142','141','140','139',
   '138','137','134','133','132','131','130',' 129','128','127'
    ]
    
  end

  def self.down
  end
end

