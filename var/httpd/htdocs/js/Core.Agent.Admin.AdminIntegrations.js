"use strict";



var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

Vue.component('component-a', { template: '<p>AAAA</p>' })


Core.Vue = new Vue({
    el: '#app',
    vuetify: new Vuetify(),
    data: () => {
      
      return {
        dialog: false,  
        cards: [],
        integrationName: "",
        component: 'component-a',
        updating: false,
        snackbar: false,
        snackbarError: false,
        text: '',
    }},
    watch: {
      options: {
        handler () {
          this.updating = true;
          this.getDataFromApi()
            .then(data => {
              this.preparerData(data);
            })
        },
        deep: true,
      },
    },
    mounted () {
      this.updating = true;
      this.getDataFromApi()
        .then(data => {
          this.preparerData(data);
        })
    },
    methods: {
      getDataFromApi () {
        return new Promise((resolve, reject) => {
          var Data = {
            Action: 'AdminIntegrations',
            Subaction: 'GetIntegrationList'
          };

          Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            for (const integration of Response) {
              Data = {
                Action: integration.Module,
                Subaction: 'GetTemplateData'
              };
              integration.TemplateData = new Promise((resolve, reject) => {
                Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                  resolve(
                    Response
                  )
                })
              });
              
            }
            resolve(
              Response
            )
          });
        });
      },
      openConfiguration (IntegrationId) {
        if(IntegrationId == undefined){
          this.component = 'component-a'
        } else {
          this.component = IntegrationId
        }
      },
      doActivate(card, index){
        card.updating = true;

        console.log("Index ",index);

        var Data = {
          Action: card.Module,
          Subaction: 'SetEnable',
          Value: card.Enable? "1": "0"
        };

        new Promise((resolve, reject) => {
          Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            resolve(Response)
          });
        }).then(value => {
          if(value.Result == 1){
            this.snackbar = true;
            if(value.Message)
              this.text = value.Message;
            else
              this.text = "Save with success";
          } else {
            this.snackbarError = true;
            if(value.Message)
              this.text = value.Message;
            else
              this.text = "Fail to save";
          }
          Core.Vue.$data.cards[index].updating = false;
        });
      },
      preparerData(data){
        this.cards = data;
          this.updating = false;
          for (const a of this.cards) {
            this.updating = true;
            a.TemplateData.then(val =>{
              this.updating = false;
              a.Enable = val.Enable;
              val.DataStructure.Module = a.Module;
              val.DataStructure.valid = true;
              val.DataStructure.IntegrationId = a.IntegrationId;
              Vue.component(a.IntegrationId, 
                { 
                  template: val.Template, 
                  data () {
                    return val.DataStructure
                  },
                  methods: {
                    closeDialog() {
                      Core.Vue.$data.dialog = false;
                    },
                    validate (formName,callback) {
                      if(this.$refs[formName].validate()){
                        callback();
                      }
                    },
                    reset (formName) {
                      this.$refs[formName].reset()
                    },
                    resetValidation (formName) {
                      this.$refs[formName].resetValidation()
                    },
                    doConfigure(){
                      var Data = {
                        Action: this._data.Module,
                        Subaction: 'SendConfigData',
                        Data: JSON.stringify(this._data)
                      };
                      new Promise((resolve, reject) => {
                        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                          resolve(
                            Response
                          )
                        })
                      }).then(val => {
                        if(val.Result == 1){
                          Core.Vue.$data.snackbar = true;
                          if(val.Message)
                            Core.Vue.$data.text = val.Message;
                          else
                            Core.Vue.$data.text = "Save with success";
                          Object.assign(this.$data, val.Data.DataStructure);
                          Core.Vue.$data.dialog = false;
                          for (const card of Core.Vue.$data.cards) {
                            if(card.IntegrationId === this._data.IntegrationId){
                              card.Enable = val.Data.Enable;
                            }
                          }
                          console.log("Module data ",val);
                        } else {
                          Core.Vue.$data.snackbarError = true;
                          Core.Vue.$data.text = val.Message;
                        }
                      });
                    }
                  } 
                });
                
            });
            
          }
      }
    }
})

