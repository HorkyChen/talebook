<template>
  <div>
    <v-row>
      <v-col cols=12>
        <h2>{{ $t('listBook.title') }}</h2>
        <v-divider class="mt-3 mb-0"></v-divider>
      </v-col>

      <v-col>
        <book-cards :books="books"></book-cards>
      </v-col>

      <v-col cols=12>
        <v-container class="max-width">
          <v-pagination v-if="page_cnt > 0" v-model="page" :length="page_cnt" circle
                        @input="change_page"></v-pagination>
        </v-container>
        <div class="text-xs-center book-pager">
        </div>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import BookCards from "../components/BookCards.vue";

export default {
  components: {
    BookCards,
  },
  computed: {},
  data: () => ({
    title: "",
    page: 1,
    books: [],
    total: 0,
    page_size: 60,
    page_cnt: 0,
    inited: false,
  }),
  async asyncData({route, app, res}) {
    if (res !== undefined) {
      res.setHeader('Cache-Control', 'no-cache');
    }
    return app.$backend(route.fullPath);
  },
  head() {
    switch (this.$route.path) {
      case "/hot":
        return {title: this.$t('listBook.hotBooks')};

      case "/search":
        return {title: this.$t('listBook.search')};

      case "/recent":
        return {title: this.$t('listBook.recentUpdates')};

      default:
        break
    }

    if (this.$route.params.meta !== undefined) {
      var name = decodeURIComponent(this.$route.params.name);
      var titles = {
        tag: this.$t('listBook.tagBooks', { name }),
        series: this.$t('listBook.seriesBooks', { name }),
        rating: this.$t('listBook.ratingBooks', { name }),
        author: this.$t('listBook.authorBooks', { name }),
        publisher: this.$t('listBook.publisherBooks', { name }),
      }
      var meta = this.$route.path.split("/")[1];
      if (titles[meta] !== undefined) {
        return {
          title: titles[meta]
        }
      }
    }

    return {
      title: this.title,
    }
  },
  created() {
    if (this.$route.query.start != undefined) {
      this.page = 1 + parseInt(this.$route.query.start / this.page_size)
    }
    if (!this.inited) {

    }
    this.page_cnt = Math.max(1, Math.ceil(this.total / this.page_size))

  },

  beforeRouteUpdate(to, from, next) {
    this.init(to, next);
  },
  methods: {
    init(route, next) {
      this.inited = true;
      this.$store.commit('navbar', true);
      this.$backend(route.fullPath)
        .then(rsp => {
          if (rsp.err != 'ok') {
            this.alert("error", rsp.msg);
            return;
          }
          this.title = rsp.title;
          this.books = rsp.books;
          this.total = rsp.total
          this.page_cnt = Math.max(1, Math.ceil(this.total / this.page_size));
        })
      if (next) next();
    },
    change_page() {
      var r = Object.assign({}, this.$route.query);
      if (this.page < 1) {
        this.page = 1
      }
      r.start = (this.page - 1) * this.page_size;
      r.size = this.page_size;
      this.$router.push({query: r});
    }
  },
}
</script>

<style scoped>
.book-list-legend {
  margin-top: 6px;
  margin-bottom: 16px;
}

.book-pager {
  margin-top: 30px;
}
</style>
