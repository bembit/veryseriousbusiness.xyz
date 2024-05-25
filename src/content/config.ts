import { z, defineCollection } from "astro:content";

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

export const collections = {
  posts: postsCollection
};
