// Import utilities from `astro:content`
import { z, defineCollection } from "astro:content";
// Define a `type` and `schema` for each collection
const postsCollection = defineCollection({
    type: 'content',
    schema: z.object({
      title: z.string(),
      pubDate: z.date(),
      description: z.string(),
      author: z.string(),
      tags: z.array(z.string()),
      contentSize: z.string().optional(),
      assetCount: z.object({
        images: z.string().optional(),
        videos: z.string().optional(),
      }),
    })
});

// Export a single `collections` object to register your collection(s)
export const collections = {
  posts: postsCollection
};



