<template>
    <div>
        <v-row align=start v-if="history.length == 0">
            <v-col cols=12>
                <p class="title"> {{ $t('history.noRecords') }} </p>
            </v-col>
        </v-row>
        <v-row v-else v-for="item in history" :key="item.name">
            <v-col cols=12>
                <legend>{{ $t(`history.${item.name}`) }}</legend>
                <v-divider></v-divider>
            </v-col>
            <v-col cols=12 v-if="item.books.length==0" >
                <p class="pb-6">{{ $t('history.noBooks') }}</p>
            </v-col>
            <v-col cols=4 sm=2 v-else v-for="book in item.books" :key="item.name + book.id">
                <v-card :to="book.href" class="ma-1">
                    <v-img :src="book.img" :aspect-ratio="11/15" > </v-img>
                </v-card>
            </v-col>
        </v-row>
    </div>
</template>

<script>
export default {
    components: {
    },
    computed: {
        history: function() {
            if ( this.user.extra === undefined ) { return [] }
            return [
                { name: 'onlineReading', books: this.get_history(this.user.extra.read_history) },
                { name: 'pushedBooks', books: this.get_history(this.user.extra.push_history) },
                { name: 'visitRecords', books: this.get_history(this.user.extra.visit_history) },
            ]
        },
    },
    data: () => ({
        user: {},
    }),
    async asyncData({ params, app, res }) {
        if ( res !== undefined ) {
            res.setHeader('Cache-Control', 'no-cache');
        }
        return app.$backend("/user/info?detail=1");
    },
    head() {
        return { title: this.$t('appHeader.reading_history') };
    },
    created() {
        this.init(this.$route);
    },
    beforeRouteUpdate(to, from, next) {
        this.init(to, next);
    },
    methods: {
        init(route, next) {
            this.$store.commit('navbar', true);
            this.$backend("/user/info?detail=1")
            .then( rsp => {
                this.user = rsp.user;
            });
            if ( next ) next();
        },
        get_history(his) {
            if ( ! his ) { return []; }
            return his.map( b => {
                b.href = '/book/' + b.id;
                return b;
            });
        },
    },
}
</script>

<style></style>
