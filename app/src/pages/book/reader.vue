<template>
  <div class="book-reader-page">
    <client-only>
        <EpubReader
        :url="bookUrl"
        :location="currentLocation"
        @locationChanged="saveLocation"
        :tocChanged="handleTocChanged"
        />
    </client-only>
  </div>
</template>

<script>
import EpubReader from '@/components/EpubReader.vue'

export default {
  components: {
    EpubReader
  },
  data() {
    return {
      bookUrl: '/home/horky/workspace/bookbarn/uploads/0623/1000.epub',
      currentLocation: localStorage.getItem('book-location') || null,
      toc: []
    }
  },
  methods: {
    saveLocation(location) {
      this.currentLocation = location
      localStorage.setItem('book-location', location)
    },
    handleTocChanged(toc) {
      this.toc = toc
      console.log('Table of contents:', toc)
    }
  }
}
</script>

<style>
.book-reader-page {
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
}
</style>
