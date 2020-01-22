new Vue({
    el: '#app',
    vuetify: new Vuetify(),
    data: () => {return {
        headers:[
            {
                text: 'Integração',
                align: 'left',
                sortable: false,
                value: 'name',
              },
              { text: 'Status', value: 'status', sortable: false },
              { text: 'Action', value: 'action', sortable: false },
        ],
        desserts: [
            {
                name: 'Frozen Yogurt'
              },
              {
                name: 'Ice cream sandwich'
              },
              {
                name: 'Eclair'
              },
              {
                name: 'Cupcake'
              },
              {
                name: 'Gingerbread'
              },
              {
                name: 'Jelly bean'
              },
              {
                name: 'Lollipop'
              },
              {
                name: 'Honeycomb'
              },
              {
                name: 'Donut'
              },
              {
                name: 'KitKat'
              },
        ]
    }}
})