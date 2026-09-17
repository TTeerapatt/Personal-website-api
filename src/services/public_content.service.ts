import { getPublicAboutMe } from "./about_me.service";
import { getPublicContactMe } from "./contact_me.service";
import { getEducationList } from "./education.service";
import { getExperiences } from "./experiences.service";
import { getActiveHomeBanners } from "./home_banners.service";
import { getProjects } from "./projects.service";
import { getSkills } from "./skills.service";
import {
  getSiteSettings,
  type SiteSettings,
} from "./site_settings.service";

export type PublicWebsiteContent = {
  settings: Pick<
    SiteSettings,
    | "show_banners"
    | "show_about_me"
    | "show_skills"
    | "show_projects"
    | "show_experiences"
    | "show_education"
    | "show_contact_me"
  >;
  banners?: Awaited<ReturnType<typeof getActiveHomeBanners>>;
  about_me?: Awaited<ReturnType<typeof getPublicAboutMe>>;
  skills?: Awaited<ReturnType<typeof getSkills>>;
  projects?: Awaited<ReturnType<typeof getProjects>>;
  experiences?: Awaited<ReturnType<typeof getExperiences>>;
  education?: Awaited<ReturnType<typeof getEducationList>>;
  contact_me?: Awaited<ReturnType<typeof getPublicContactMe>>;
};

/**
 * Aggregate public website payload.
 * Sections with site_settings.show_* = false are omitted entirely.
 * List items are limited to deleted_at IS NULL AND is_active = TRUE.
 */
export async function getPublicWebsiteContent(): Promise<PublicWebsiteContent> {
  const settings = await getSiteSettings();

  const data: PublicWebsiteContent = {
    settings: {
      show_banners: settings.show_banners,
      show_about_me: settings.show_about_me,
      show_skills: settings.show_skills,
      show_projects: settings.show_projects,
      show_experiences: settings.show_experiences,
      show_education: settings.show_education,
      show_contact_me: settings.show_contact_me,
    },
  };

  const tasks: Promise<void>[] = [];

  if (settings.show_banners) {
    tasks.push(
      getActiveHomeBanners({ is_active: true }).then((rows) => {
        data.banners = rows;
      })
    );
  }

  if (settings.show_about_me) {
    tasks.push(
      getPublicAboutMe().then((row) => {
        data.about_me = row;
      })
    );
  }

  if (settings.show_skills) {
    tasks.push(
      getSkills({ is_active: true }).then((rows) => {
        data.skills = rows;
      })
    );
  }

  if (settings.show_projects) {
    tasks.push(
      getProjects({ is_active: true }).then((rows) => {
        data.projects = rows;
      })
    );
  }

  if (settings.show_experiences) {
    tasks.push(
      getExperiences({ is_active: true }).then((rows) => {
        data.experiences = rows;
      })
    );
  }

  if (settings.show_education) {
    tasks.push(
      getEducationList({ is_active: true }).then((rows) => {
        data.education = rows;
      })
    );
  }

  if (settings.show_contact_me) {
    tasks.push(
      getPublicContactMe().then((row) => {
        data.contact_me = row;
      })
    );
  }

  await Promise.all(tasks);
  return data;
}
